const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  username: String,
  password: String,
  role: String,
  profit: Number,
  sales: Number,
  rawMaterials: Array,
  inventory: {
    underProcess: Number,
    waitingForApproval: Number,
    sold: Number,
  },
});

module.exports = mongoose.model("User", userSchema);
