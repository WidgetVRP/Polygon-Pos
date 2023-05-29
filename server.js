const express = require('express');
const Web3 = require('web3');
const RaffleABI = [
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "winner",
				"type": "address"
			}
		],
		"name": "RaffleDrawn",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "claimPrize",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "drawWinner",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "enter",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "entries",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "isClosed",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "participants",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "winner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];
const RaffleAddress = '0x123456789...'; // Address of your deployed Raffle contract
const app = express();
const web3 = new Web3('http://localhost:8545'); // Connect to your local Ethereum node

// Create an instance of your Raffle contract using its ABI and address
const raffleContract = new web3.eth.Contract(RaffleABI, RaffleAddress);

// Serve the HTML file when someone loads the root URL
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/index.html');
});

// Handle the POST request when someone enters the raffle
app.post('/enter', async (req, res) => {
    try {
        const accounts = await web3.eth.getAccounts();
        const options = { from: accounts[0], value: web3.utils.toWei('1', 'ether') };
        await raffleContract.methods.enter().send(options);
        res.redirect('/');
    } catch (error) {
        console.error(error);
        res.status(500).send('Error entering raffle');
    }
});

// Handle the POST request when someone draws the winner
app.post('/draw', async (req, res) => {
    try {
        const accounts = await web3.eth.getAccounts();
        const options = { from: accounts[0] };
        await raffleContract.methods.drawWinner().send(options);
        res.redirect('/');
    } catch (error) {
        console.error(error);
        res.status(500).send('Error drawing winner');
    }
});

// Start the server
app.listen(3000, () => {
    console.log('Server is listening on port 3000');
});
