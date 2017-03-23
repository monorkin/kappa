FROM node

COPY . .
RUN npm install --global babel-cli
RUN npm install --save-dev babel-core babel-preset-es2015
RUN npm install
RUN npm run transpile

WORKDIR /app
CMD "./start.sh"
