# Local Payment OpenAPI Specification


## Working on specification
### Install

1. Install [Node JS](https://nodejs.org/)
2. Install *redoc-cli* `npm install redoc-cli`
3. Clone repo and run `npm install` in the repo root

### Usage

#### `npm start`
Starts the development server.

#### `npm run build`
Bundles the spec and prepares web_deploy folder with static assets.

#### `npm test`
Validates the spec.

#### `redoc-cli bundle [spec]`
Create a bundle version from static HTML
Example `redoc-cli bundle C:[Pathroot]openapi.yaml --options.theme.rightPanel.width="35%"`