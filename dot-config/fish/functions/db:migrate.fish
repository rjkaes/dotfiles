function db:migrate --argument title
    set -l ts (date +'%Y%m%d%H%M%S')
    set -l file $ts-$title.sql

    touch $file && nvim $file
end
