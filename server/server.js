const express = require("express");
const mongoose = require("mongoose");
const authRoutes = require("./routes/authRoutes");
const adminRoutes = require("./routes/adminRoutes");
const userRoutes = require("./routes/userRoutes");

const app = express();
app.use(express.json());

mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });

app.use("/api/login", authRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/user", userRoutes);

app.listen(5000, () => {
  console.log("Server is running on port 5000");
});
