import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import Home from "./page"; // Assuming page.tsx is in the same directory

describe("Home Page", () => {
	it("renders initial instructions", () => {
		render(<Home />);
		// Check for the introductory text instead of a specific heading
		expect(
			screen.getByText(/get started by editing/i)
		).toBeInTheDocument();
	});

	// Add more tests here, e.g.:
	// it('handles interaction', async () => {
	//   render(<Home />);
	//   const user = userEvent.setup();
	//   await user.click(screen.getByRole(...));
	//   expect(...).toBe(...);
	// });
}); 