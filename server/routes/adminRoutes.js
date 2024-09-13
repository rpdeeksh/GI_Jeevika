const express = require("express");
const User = require("../models/User");
const RawMaterial = require("../models/RawMaterial");

const router = express.Router();

router.get("/data", async (req, res) => {
  const users = await User.find({ role: "user" });
  const rawMaterials = await RawMaterial.find({});
  res.json({ users, rawMaterials });
});

module.exports = router;
