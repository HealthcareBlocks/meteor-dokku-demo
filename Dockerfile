FROM healthcareblocks/meteordemo
ADD nginx.conf.sigil /
CMD node main.js
