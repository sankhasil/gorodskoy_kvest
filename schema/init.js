// mongo-init/init.js — seed an admin user and a sample puzzle
db = db.getSiblingDB('treasurehunt');

// Create admin user
db.users.insertOne({
  email: "admin@treasurehunt.com",
  passwordHash: "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy", // password: "admin123"
  displayName: "Admin",
  role: "ADMIN",
  createdAt: new Date(),
  active: true
});

// Create a sample puzzle
const puzzleId = ObjectId();
db.puzzles.insertOne({
  _id: puzzleId,
  title: "The Lost City",
  description: "Navigate through ancient riddles to discover the lost city of gold.",
  difficulty: "MEDIUM",
  active: true,
  createdBy: "seed",
  tags: ["history", "adventure"],
  estimatedMinutes: 30,
  createdAt: new Date(),
  updatedAt: new Date()
});

// Sample clues
db.clues.insertMany([
  {
    puzzleId: puzzleId.toString(),
    orderIndex: 0,
    type: "RIDDLE",
    content: "I have cities, but no houses live there. I have mountains, but no trees grow. I have water, but no fish swim. I have roads, but no cars drive. What am I?",
    hint: "You unfold me before a road trip",
    answer: "map",
    createdAt: new Date()
  },
  {
    puzzleId: puzzleId.toString(),
    orderIndex: 1,
    type: "TEXT",
    content: "The explorer always carries this to find direction. It has a needle that always points north.",
    hint: "Sailors used it before GPS",
    answer: "compass",
    createdAt: new Date()
  },
  {
    puzzleId: puzzleId.toString(),
    orderIndex: 2,
    type: "TEXT",
    content: "What ancient structure do archaeologists dig to find artifacts? Starts with R.",
    hint: "Think of buried treasure sites",
    answer: "ruins",
    createdAt: new Date()
  }
]);

print('✅ Seed data inserted successfully');