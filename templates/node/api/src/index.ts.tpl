import express from 'express';

const app = express();
const port = process.env.PORT || {{port}};

app.use(express.json());

// Basic health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(port, () => {
  console.log(`🚀 Server running at http://localhost:${port}`);
}); 