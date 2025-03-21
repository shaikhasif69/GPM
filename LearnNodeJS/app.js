const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const dotenv = require("dotenv");

const userRoutes = require("./Routers/userRoutes");
const projectRoutes = require("./Routers/projectRoutes");
const favoriteDayRoutes = require("./Routers/favoriteDayRoutes");

dotenv.config();
const app = express();
console.log("hello world");
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5000;
const MONGODB_URI =
  process.env.MONGODB_URI ||
  "mongodb+srv://theshaikhasif03:b1NAmqjhyuvjl4b9@gpmcluster.uo5gw.mongodb.net/?retryWrites=true&w=majority&appName=GPMCluster";

mongoose
  .connect(MONGODB_URI)
  .then(() => console.log("Connected to MongoDB"))
  .catch((err) => console.error("MongoDB connection error:", err));

app.use("/api/users", userRoutes);
app.use("/api/favoritedays", favoriteDayRoutes);
// app.use('/api/projects', projectRoutes);

app.get("/", (req, res) => {
  res.send("Student Portal API is running");
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
