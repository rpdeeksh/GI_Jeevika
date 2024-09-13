import React, { useEffect, useState } from "react";

function UserDashboard() {
  const [dashboardData, setDashboardData] = useState({});

  useEffect(() => {
    async function fetchData() {
      const response = await fetch("/api/user/data");
      const data = await response.json();
      setDashboardData(data);
    }
    fetchData();
  }, []);

  return (
    <div>
      <h1>User Dashboard</h1>
      <h2>Profit: {dashboardData.profit}</h2>
      <h2>Sales: {dashboardData.sales}</h2>
      <h2>Raw Materials</h2>
      <ul>
        {dashboardData.rawMaterials?.map((material, index) => (
          <li key={index}>{material.name} - {material.quantity}</li>
        ))}
      </ul>
      <h2>Inventory</h2>
      <ul>
        <li>Under Process: {dashboardData.underProcess}</li>
        <li>Waiting for Approval: {dashboardData.waitingForApproval}</li>
        <li>Sold: {dashboardData.sold}</li>
      </ul>
    </div>
  );
}

export default UserDashboard;
