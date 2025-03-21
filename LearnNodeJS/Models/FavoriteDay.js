const mongoose = require("mongoose");

const favoriteDaySchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  date: {
    type: Date,
    required: true,
  },
  weatherData: {
    temperature: Number,
    description: String,
    icon: String,
    humidity: Number,
    windSpeed: Number,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});
favoriteDaySchema.index({ userId: 1, date: 1 }, { unique: true });
module.exports = mongoose.model("FavoriteDay", favoriteDaySchema);
