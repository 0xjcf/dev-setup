import assert from "node:assert";
import type { Server } from "node:http";
import { after, before, describe, test } from "node:test";
import request from "supertest";
import app from "../src/index";

// Use describe to group tests and manage server lifecycle
describe("API Tests", () => {
	let server: Server;
	// Infer the type directly from the function's return type
	let agent: ReturnType<typeof request.agent>;

	before(async () => {
		// Start the server on a random available port before tests
		server = app.listen();
		// Create a supertest agent bound to the running server
		agent = request.agent(server);
	});

	after(async () => {
		// Close the server after tests
		await new Promise<void>((resolve, reject) => {
			server.close((err) => {
				if (err) return reject(err);
				resolve();
			});
		});
	});

	test("should return a welcome message", async () => {
		const response = await agent.get("/");
		assert.strictEqual(response.status, 200);
		assert.deepStrictEqual(response.body, { message: "API is running" });
	});

	test("should return health check information", async () => {
		const response = await agent.get("/health");
		assert.strictEqual(response.status, 200);
		assert.strictEqual(response.body.status, "healthy");
		assert.ok(response.body.uptime);
		assert.ok(response.body.memory);
		assert.ok(response.body.environment);
		assert.ok(response.body.nodeVersion);
		assert.ok(response.body.platform);
		assert.ok(response.body.hostname);
	});
});
