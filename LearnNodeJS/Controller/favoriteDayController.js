const FavoriteDay = require("../Models/FavoriteDay");
const User = require("../Models/User");

exports.addFavoriteDay = async (req, res) => {
  try {
    const { userId, date, weatherData } = req.body;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const formattedDate = new Date(date).toISOString().split("T")[0];

    const existingFavorite = await FavoriteDay.findOne({
      userId,
      date: {
        $gte: new Date(`${formattedDate}T00:00:00.000Z`),
        $lte: new Date(`${formattedDate}T23:59:59.999Z`),
      },
    });

    if (existingFavorite) {
      return res
        .status(400)
        .json({ message: "This day is already a favorite" });
    }

    const favoriteDay = new FavoriteDay({
      userId,
      date: new Date(date),
      weatherData,
    });

    const savedFavoriteDay = await favoriteDay.save();

    user.favoriteDays.push(savedFavoriteDay._id);
    await user.save();

    res.status(201).json({
      _id: savedFavoriteDay._id.toString(),
      userId: savedFavoriteDay.userId.toString(),
      date: savedFavoriteDay.date,
      weatherData: savedFavoriteDay.weatherData,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.removeFavoriteDay = async (req, res) => {
  try {
    const { id } = req.params;
    const favoriteDay = await FavoriteDay.findById(id);

    if (!favoriteDay) {
      return res.status(404).json({ message: "Favorite day not found" });
    }

    await User.findByIdAndUpdate(favoriteDay.userId, {
      $pull: { favoriteDays: id },
    });

    // Delete the favorite day
    await FavoriteDay.findByIdAndDelete(id);

    res.status(200).json({ message: "Favorite day removed successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getUserFavoriteDays = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Get all favorite days for the user
    const favoriteDays = await FavoriteDay.find({ userId }).sort({ date: -1 });

    res.status(200).json(favoriteDays);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
