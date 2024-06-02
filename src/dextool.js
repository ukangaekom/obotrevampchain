
// API DEXTOOL

// Blockchain

// Exchange

// Token
    



const projectChainInfo = document.querySelector('.project_chain_info')



const orcProjects = {
    'cocoaland':['Ethereum','Avalanche','Polygon','Scroll']

}


const displayChainData = function (list) {
    let chainDataComponents = ''
    for (i of list) {
        chainDataComponents += `
        <div class="chain">
            <div class="chain_brand">
              <div class="chain_logo">
                <img src="./public/images/chains/${i}.png" alt="">
              </div>
              <div class="chain_name">
                <h2>Ethereum Sepolia</h2>
              </div>
            </div>
            <div class="circulating_supply data_box">
              <h2 class="data_feature">Circulating:</h2>  
              <h2 class="data">10000000</h2> 
            </div>
            <div class="uncirculating_supply data_box">
              <h2 class="data_feature">Locked:</h2>
              <h2 class="data">10000000</h2> 
            </div>
            <div class="pool_liquidity data_box">
              <h2 class="data_feature">Liqudity:</h2>
              <h2 class="data">#10000000</h2> 
            </div>
            <div class="minted_nfts data_box data_box">
              <h2 class="data_feature">MintedNFTs:</h2>
              <h2 class="data">100</h2> 
            </div>
            <div class="unminted_nfts data_box">
              <h2 class="data_feature">UnmintedNFTs:</h2>
              <h2 class="data">100</h2> 
            </div>
          </div>
        `
    }

    return chainDataComponents;
}

console.log(displayChainData(orcProjects['cocoaland']))

projectChainInfo.innerHTML = displayChainData(orcProjects['cocoaland'])