import React, { useState } from "react";
import { BrowserRouter as Router, Route, Routes, Navigate } from "react-router-dom";
import Login from "./components/Login";
import AdminDashboard from "./pages/AdminDashboard";
import UserDashboard from "./pages/UserDashboard";

function App() {
  const [role, setRole] = useState(null); // To track logged-in user's role

  return (
    <Router>
      <Routes>
        <Route path="/" element={<Login setRole={setRole} />} />
        <Route
          path="/admin"
          element={role === "admin" ? <AdminDashboard /> : <Navigate to="/" />}
        />
        <Route
          path="/user"
          element={role === "user" ? <UserDashboard /> : <Navigate to="/" />}
        />
      </Routes>
    </Router>
  );
}

export default App;
