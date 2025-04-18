import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import App from './App'; // Assuming App.tsx is in the same directory

describe('App Component', () => {
  it('renders headline', () => {
    render(<App />);
    expect(screen.getByRole('heading', { name: /vite \+ react/i })).toBeInTheDocument();
  });

  it('increments count on button click', async () => {
    render(<App />);
    const button = screen.getByRole('button', { name: /count is 0/i });
    await userEvent.click(button);
    expect(screen.getByRole('button', { name: /count is 1/i })).toBeInTheDocument();
  });
}); 