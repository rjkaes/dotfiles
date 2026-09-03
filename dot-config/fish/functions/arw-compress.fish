function arw-compress
    /opt/homebrew/bin/parallel 'xz -T1 --lzma2=preset=9e,lc=4,lp=0,pb=0 {}' ::: *.ARW
end
