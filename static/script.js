document.addEventListener('DOMContentLoaded', function() {
    const approvedTable = document.querySelector('#approvedTBody');
    const pendingTable = document.querySelector('#pendingTBody');
    const searchInput = document.getElementById('searchInput');
    let approvedProducts = [];
    let pendingProducts = [];
    const itemsPerPage = 30;
    let currentApprovedPage = 1;
    let currentPendingPage = 1;

    // Fetch products data from the API
    fetch('/api/products')
        .then(response => response.json())
        .then(data => {
            approvedProducts = data.approved_products; // Approved products
            pendingProducts = data.pending_products; // Pending products

            renderTable(approvedTable, approvedProducts, currentApprovedPage); // Render approved products
            renderTable(pendingTable, pendingProducts, currentPendingPage); // Render pending products

            setupPagination(approvedProducts, approvedTable, 'approved'); // Pagination for approved products
            setupPagination(pendingProducts, pendingTable, 'pending'); // Pagination for pending products
        })
        .catch(error => console.error('Error fetching products:', error));

    // Search functionality
    searchInput.addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase();

        const filteredApproved = approvedProducts.filter(product => {
            return searchFilter(product, searchTerm);
        });

        const filteredPending = pendingProducts.filter(product => {
            return searchFilter(product, searchTerm);
        });

        renderTable(approvedTable, filteredApproved, currentApprovedPage);
        renderTable(pendingTable, filteredPending, currentPendingPage);

        setupPagination(filteredApproved, approvedTable, 'approved');
        setupPagination(filteredPending, pendingTable, 'pending');
    });

    // Function to render table rows
    function renderTable(tableBody, products, currentPage) {
        tableBody.innerHTML = ''; // Clear the table

        const paginatedData = products.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);
        paginatedData.forEach(product => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${product.date}</td>
                <td>${product.username}</td>
                <td>${product.product_category}</td>
                <td>${product.product_quality}</td>
                <td>${product.approved_price || 'N/A'}</td>
                <td>${product.return_status}</td>
                <td>${product.sold_status}</td>
                <td>${product.payment_status}</td>
                <td>${product.quality_control}</td>
                <td>${product.trackability_key}</td>
                <td>
                    <a href="/product/edit/${product.id}">Edit</a>
                    <a href="/product/delete/${product.id}" onclick="return confirm('Are you sure you want to delete this product?')">Delete</a>
                </td>
            `;
            tableBody.appendChild(row);
        });
    }

    // Search filter function
    function searchFilter(product, searchTerm) {
        return product.product_category.toLowerCase().includes(searchTerm) ||
               product.product_quality.toLowerCase().includes(searchTerm) ||
               product.username.toLowerCase().includes(searchTerm);
    }

    // Pagination setup function
    function setupPagination(products, tableBody, type) {
        const pageCount = Math.ceil(products.length / itemsPerPage);
        const paginationContainer = document.querySelector(`#${type}Pagination`);
        paginationContainer.innerHTML = '';

        for (let i = 1; i <= pageCount; i++) {
            const pageButton = document.createElement('button');
            pageButton.textContent = i;
            pageButton.addEventListener('click', () => {
                if (type === 'approved') {
                    currentApprovedPage = i;
                    renderTable(approvedTable, products, currentApprovedPage);
                } else {
                    currentPendingPage = i;
                    renderTable(pendingTable, products, currentPendingPage);
                }
            });
            paginationContainer.appendChild(pageButton);
        }
    }



    function renderCharts(data) {
        if (!data.adminStatus) {
            // User Charts
            Plotly.newPlot('sold-unsold-chart', [{
                labels: ['Sold', 'Unsold'],
                values: [data.soldCount, data.unsoldCount],
                type: 'pie'
            }], { title: 'Sold vs Unsold Products' });

            Plotly.newPlot('approved-not-approved-chart', [{
                labels: ['Approved', 'Not Approved'],
                values: [data.approvedCount, data.notApprovedCount],
                type: 'pie'
            }], { title: 'Approved vs Not Approved Products' });

            Plotly.newPlot('returned-not-returned-chart', [{
                labels: ['Returned', 'Not Returned'],
                values: [data.returnedCount, data.notReturnedCount],
                type: 'pie'
            }], { title: 'Returned vs Not Returned Products' });

            Plotly.newPlot('quality-control-chart', [{
                labels: ['Passed', 'Failed'],
                values: [data.passedQCCount, data.failedQCCount],
                type: 'pie'
            }], { title: 'Quality Control Pass vs Fail' });

            // Bar chart for individual user: Products produced by the user on specific dates
            Plotly.newPlot('production-time-series', [{
                x: data.dates,  // Date on the x-axis
                y: data.productCounts,  // Total products produced on that date for the user
                type: 'bar',  // Set the chart type to bar
            }], {
                title: 'Products Produced Per Day',
                xaxis: { 
                    title: 'Date',
                    tickformat: '%Y-%m-%d'  // Display only the date in YYYY-MM-DD format
                },
                yaxis: { title: 'Total Products Produced' },
                bargap: 0.05,  // Small gap between bars
                barmode: 'group',
            });

        } else {
            // Admin Charts
            Plotly.newPlot('products-by-user-chart', [{
                labels: data.productsByUser,
                values: data.productsByUserValues,
                type: 'pie'
            }], { title: 'Products by User' });

            Plotly.newPlot('total-approved-not-approved-chart', [{
                labels: ['Approved', 'Not Approved'],
                values: [data.totalApprovedCount, data.totalNotApprovedCount],
                type: 'pie'
            }], { title: 'Total Approved vs Not Approved Products' });

            Plotly.newPlot('total-sold-unsold-chart', [{
                labels: ['Sold', 'Unsold'],
                values: [data.totalSoldCount, data.totalUnsoldCount],
                type: 'pie'
            }], { title: 'Total Sold vs Unsold Products' });

            Plotly.newPlot('total-returned-not-returned-chart', [{
                labels: ['Returned', 'Not Returned'],
                values: [data.totalReturnedCount, data.totalNotReturnedCount],
                type: 'pie'
            }], { title: 'Total Returned vs Not Returned Products' });

            Plotly.newPlot('total-quality-control-chart', [{
                labels: ['Passed', 'Failed'],
                values: [data.totalPassedQCCount, data.totalFailedQCCount],
                type: 'pie'
            }], { title: 'Total Quality Control Pass vs Fail' });

            // Bar chart for admin: Total products produced by all users on specific dates
            Plotly.newPlot('total-production-time-series', [{
                x: data.dates,  // Date on the x-axis
                y: data.productCounts,  // Total products produced on that date by all users
                type: 'bar',  // Set the chart type to bar
            }], {
                title: 'Total Products Produced Per Day',
                xaxis: { 
                    title: 'Date',
                    tickformat: '%Y-%m-%d'  // Display only the date in YYYY-MM-DD format
                },
                yaxis: { title: 'Total Products Produced' },
                bargap: 0.05,  // Small gap between bars
                barmode: 'group',
            });
        }
    }


    // Fetch dashboard data
    fetch('/api/dashboard')
        .then(response => response.json())
        .then(data => {
            renderCharts(data); // Render charts with the fetched data
        })
        .catch(error => console.error('Error fetching dashboard data:', error));
});
