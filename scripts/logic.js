let erc20 = []
let nfts = []
let tok = 0;

const addNFT = (nft) => {
    nfts.push(nft);
    erc20.push(tok)
    tok++;
    return tok;
}
const getRandomNFT = (erc_token) => {
    if (erc20.includes(erc_token)) {
        erc20.splice(erc20.indexOf(erc_token), 1)
        let nft = nfts[Math.floor(Math.random() * nfts.length)];
        nfts.splice(nfts.indexOf(nft), 1);
        return nft;
    }
}
