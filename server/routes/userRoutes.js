const express = require("express");
const User = require("../models/User");

const router = express.Router();

router.get("/data", async (req, res) => {
  const user = await User.findOne({ username: "some_user" }); // Example user
  res.json({
    profit: user.profit,
    sales: user.sales,
    rawMaterials: user.rawMaterials,
    underProcess: user.inventory.underProcess,
    waitingForApproval: user.inventory.waitingForApproval,
    sold: user.inventory.sold,
  });
});

module.exports = router;
