// import contractABI from ''

const walletConnectButton = document.querySelector('#connect_wallet')

// Buying and Seling Shares Buttons
const buyShares = document.querySelector('.buy_shares');
const sellShares = document.querySelector('.sell_shares')

// Buying and Selling Token Buttons
const buyTokens = document.querySelector('.buy_token')
const sellTokens = document.querySelector('.sell_token')


// Buy Cocoa Button
const buyCocoa = document.querySelector('.buy_cocoa')

// Inputs Forms
const sharesInput = document.querySelector('.share_input')
const tokenInput = document.querySelector('.token_input')
const cocoaInput = document.querySelector('.cocoa_input')





const projectContractAddress = {
    'cocoaland':0
} 

let web3 = new Web3(window.ethereum);

console.log(web3)


async function connectWallet() {
    if (window.ethereum) {
        const accounts = await window.ethereum.request({ method: "eth_requestAccounts" })
            .then((response) => {
                if (response.code == "4001") {
                    console.log('please connect your wallet')
                
                } else {
                    console.log(response)
                    changeState(true)
                    
                }
            })
        
        console.log(accounts)
    }
}


function changeState(state) {
    if (state == false) {

        document.querySelector('#connect_wallet').textContent = 'Connect';
    }
    else{
        
        document.querySelector('#connect_wallet').textContent = 'Connected';
    }
}









walletConnectButton.addEventListener('click', function () {
    connectWallet()
})

function print() {
    console.log('clicked')
}


sharesInput.addEventListener('input', (event) => {
    console.log(sharesInput.value)
    
})

tokenInput.addEventListener('input', function (event) {
    console.log(tokenInput.value)
})

cocoaInput.addEventListener('input', function (event) {
    console.log(cocoaInput.value)
})

// BUYING SHARES
buyShares.addEventListener('click', function () {
    
})


// SELLING SHARES

sellShares.addEventListener('click', function () {
    
})


// BUYING TOKENS

buyTokens.addEventListener('click',function(){})


// SELLING TOKENS

sellShares.addEventListener('click', function () {
    
})


// BUY TOKEN
buyCocoa.addEventListener('click', function () {
    
})