# Example server

Example server for adding your API key to ticket purchase requests.

## Requirements
- Node.js >= 8.10.0
- Yarn (recommended)

## Usage

Run `yarn` to install dependencies.

Create your .env file by copying .env.example `cp .env.example .env`

Add your sandbox api key and sandbox order endpoint to the .env file

Run `yarn start` to start the server

Example server will be accessible at `http://localhost:3000/order` or `http://10.0.2.2:3000/order` on Android emulators
