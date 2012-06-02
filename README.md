# Mynd
Mynd/Chart means/þýðir chart/mynd in/í icelandic/íslensku

## Requirements:
### To Run:

- jQuery

### To Compile:

You can install all of the following dependencies by running:

```bash
sudo npm install -g coffee-script
npm install -d
```

- [CoffeeScript](http://coffeescript.org/) 1.3.1+
- [uglify-js](https://github.com/mishoo/UglifyJS)

## Example:
![image](https://raw.github.com/radekstepan/mynd/master/example.jpeg)

## Why:

1. Not invented here syndrome
2. Ugly d3 codebase with deprecated functions
3. Size of d3 and plethora of (useless to me) functions
4. d3 does not do charting, only acts as a wrapper for DOM
5. Google Visualization is imprecise
6. One can now use CSS to style the charts
7. VML support is deprecated and does not do wrapping `g`-like elements