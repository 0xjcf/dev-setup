import os from "node:os";
import { config } from "dotenv";
import express from "express";

config();

const app = express();
const port = process.env.PORT || 3000;
const startTime = Date.now();

app.use(express.json());

app.get("/", (req, res) => {
	res.json({ message: "API is running" });
});

app.get("/health", (req, res) => {
	const uptime = process.uptime();
	const memoryUsage = process.memoryUsage();

	res.json({
		status: "healthy",
		uptime: {
			seconds: Math.floor(uptime),
			minutes: Math.floor(uptime / 60),
			hours: Math.floor(uptime / 3600),
		},
		memory: {
			rss: `${Math.round(memoryUsage.rss / 1024 / 1024)}MB`,
			heapTotal: `${Math.round(memoryUsage.heapTotal / 1024 / 1024)}MB`,
			heapUsed: `${Math.round(memoryUsage.heapUsed / 1024 / 1024)}MB`,
		},
		environment: process.env.NODE_ENV || "development",
		nodeVersion: process.version,
		platform: os.platform(),
		hostname: os.hostname(),
	});
});

if (process.env.NODE_ENV !== "test") {
	app.listen(port, () => {
		console.log(`Server is running on port ${port}`);
	});
}

export default app;
