const express = require("express");
const User = require("../models/User");

const router = express.Router();

router.post("/", async (req, res) => {
  const { username, password } = req.body;
  const user = await User.findOne({ username });

  if (user && user.password === password) {
    res.json({ success: true, role: user.role });
  } else {
    res.json({ success: false });
  }
});

module.exports = router;
