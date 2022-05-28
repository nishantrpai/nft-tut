FROM node:14.18.0
WORKDIR /vault
COPY package.json yarn.lock ./
RUN npm i
COPY . .
CMD npx hardhat test --network hardhat
