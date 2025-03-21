const express = require("express");
const router = express.Router();
const favoriteDayController = require("../Controller/favoriteDayController");

router.post("/", favoriteDayController.addFavoriteDay);

router.get("/user/:userId", favoriteDayController.getUserFavoriteDays);

router.delete("/:id", favoriteDayController.removeFavoriteDay);

module.exports = router;