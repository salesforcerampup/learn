module.exports = {
  'sfdx-project.json': () => {
    return [`npm run package:aliases:sort`, `npx prettier --write sfdx-project.json`];
  },
  '*.cls': () => {
    return [`npm run scan`, `npm run docs:generate`];
  },
  '*.{cls,cmp,component,css,html,js,json,md,page,trigger,yaml,yml}': filenames => {
    return filenames.map(filename => `prettier --write '${filename}'`);
  }
};
