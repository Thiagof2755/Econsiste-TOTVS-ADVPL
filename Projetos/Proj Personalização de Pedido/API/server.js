const jsonServer = require('json-server');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

// Cria um servidor JSON
const server = jsonServer.create();
const router = jsonServer.router(path.join(__dirname, 'db.json'));

// Usa os middlewares do JSON Server
server.use(jsonServer.defaults());
server.use(cors());  // Permite CORS
server.use(router);

// Define a porta para o servidor
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`JSON Server is running on port ${PORT}`);
});
