FROM healthcareblocks/meteordemo
ADD nginx.conf.sigil /app/
CMD node main.js
