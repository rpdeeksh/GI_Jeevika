import React, { useEffect, useState } from "react";

function AdminDashboard() {
  const [users, setUsers] = useState([]);
  const [rawMaterials, setRawMaterials] = useState([]);

  useEffect(() => {
    async function fetchData() {
      const response = await fetch("/api/admin/data");
      const data = await response.json();
      setUsers(data.users);
      setRawMaterials(data.rawMaterials);
    }
    fetchData();
  }, []);

  return (
    <div>
      <h1>Admin Dashboard</h1>
      <h2>Authorized Users</h2>
      <ul>
        {users.map((user, index) => (
          <li key={index}>{user.username}</li>
        ))}
      </ul>
      <h2>Raw Materials</h2>
      <ul>
        {rawMaterials.map((material, index) => (
          <li key={index}>{material.name} - {material.quantity}</li>
        ))}
      </ul>
    </div>
  );
}

export default AdminDashboard;
