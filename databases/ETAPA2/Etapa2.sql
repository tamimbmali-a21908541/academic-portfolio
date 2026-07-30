 /*Boshra Alalou 21908516*/
 /*Tamim Mohamed Ali 21908541*/
 /*Sofia Barros Adriano 22104464 */




/* 5.1 */

delete from load_song_detail where musica_id not in (select musica_id from load_song);

/* 5.1 */

/* 5.2 */

select * from load_song_detail d join load_song s on d.musica_id = s.musica_id;

/* 5.2 */

/* 5.3 */

SET @row_number = 0; 
update load_song_artista set artista_id = @row_number := @row_number + 100; /*set artista_id as rownumber*/

/* 5.3 */

/* 5.4 */

select
  musica_id,
  trim(SUBSTRING_INDEX(SUBSTRING_INDEX(artists, ',', numbers.n), ',', -1)) artist, 
  artista_id + numbers.n artista_id
from
  (select round(artista_id / 100) n from load_song_artista where (select max(LENGTH(artists) - LENGTH( REPLACE ( artists, ",", "")) + 1) from load_song_artista) * 100 >= artista_id) numbers INNER JOIN load_song_artista
  on CHAR_LENGTH(artists)
     -CHAR_LENGTH(REPLACE(artists, ',', ''))>=numbers.n-1
order by
  musica_id, n;

/* 5.4 */

/* 5.5 */

/**** USING 5.4 */

select
  musica_id,
  artista_id + numbers.n artista_id
from
  (select round(artista_id / 100) n from load_song_artista where (select max(LENGTH(artists) - LENGTH( REPLACE ( artists, ",", "")) + 1) from load_song_artista) * 100 >= artista_id) numbers INNER JOIN load_song_artista
  on CHAR_LENGTH(artists)
     -CHAR_LENGTH(REPLACE(artists, ',', ''))>=numbers.n-1
order by
  musica_id, n;

/* 5.5 */

/* 6. */

CREATE TABLE musica(
        id varchar(22) primary key,
        titulo varchar(500),
        ano int,
        duracao int,
        letra_explicita tinyint,
        popularidade int,
        grau_dancabilidade double,
        grau_vivacidade double,
        volume_som_medio double
);

CREATE TABLE musica_relacionada(
        musica_id1 varchar(22) references musica (id),
        musica_id2 varchar(22) references musica (id),
        descricao varchar(10000),
        primary key (musica_id1, musica_id2)
);

CREATE TABLE album(
        id int unsigned primary key,
        nome varchar(200),
        data_lancamento date
);

CREATE TABLE faixa(
        musica_id varchar(22) references musica(id),
        album_id int unsigned references album(id),
        posicao int,
        descricao varchar(10000),
        primary key (musica_id, album_id)
);

CREATE TABLE rotulo(
        id varchar(6) primary key,
        descricao varchar(200)
);

CREATE TABLE rotulo_musica(
        musica_id varchar(22) references musica(id),
        rotulo_id varchar(6) references rotulo(id),
        primary key(musica_id, rotulo_id)
);

CREATE TABLE artista(
        id int unsigned primary key,
        nome_artistico varchar(400),
        nome_real varchar(400),
        data_nascimento date,
        biografia varchar(10000)
);

CREATE TABLE rotulo_artista(
        artista_id int unsigned references artista(id),
        rotulo_id varchar(6) references rotulo(id),
        primary key(artista_id, rotulo_id)
);

CREATE TABLE tipo_contribuicao(
        id varchar(6) primary key,
        descricao varchar(100)
);

CREATE TABLE contribuicao_artista(
        artista_id int unsigned references artista(id),
        musica_id varchar(22) references musica(id),
        tipo_contribuicao varchar(6) references tipo_contribuicao(id),
        descricao varchar(10000)
);

/* 6. */

/* 7. */

insert into musica (id, titulo, ano, duracao, letra_explicita, popularidade, grau_dancabilidade, grau_vivacidade, volume_som_medio)
select distinct(d.musica_id), titulo, ano, duracao, letra_explicita, popularidade, grau_dancabilidade, round(grau_vivacidade, 3), round(volume_som_medio, 3) 
        from load_song_detail d inner join load_song s on d.musica_id = s.musica_id;

/* 7. */

/* 8. */

insert into artista (id, nome_artistico, nome_real, data_nascimento, biografia)
select
  artista_id + numbers.n artista_id,
  trim(SUBSTRING_INDEX(SUBSTRING_INDEX(artists, ',', numbers.n), ',', -1)) nome_artistico, 
  trim(SUBSTRING_INDEX(SUBSTRING_INDEX(artists, ',', numbers.n), ',', -1)) nome_real,
  null, null
from
  (select round(artista_id / 100) n from load_song_artista where (select max(LENGTH(artists) - LENGTH( REPLACE ( artists, ",", "")) + 1) from load_song_artista) * 100 >= artista_id) numbers INNER JOIN load_song_artista
  on CHAR_LENGTH(artists)
     -CHAR_LENGTH(REPLACE(artists, ',', ''))>=numbers.n-1;

/* 8. */

/* 9. */

insert into album (id, nome, data_lancamento) values (1, 'Album 1', DATE("2017-04-15"));
insert into album (id, nome, data_lancamento) values (2, 'Album 2', DATE("2016-09-10"));
insert into album (id, nome, data_lancamento) values (3, 'Album 3', DATE("2012-11-05"));
insert into album (id, nome, data_lancamento) values (4, 'Album 4', DATE("2011-10-01"));
insert into album (id, nome, data_lancamento) values (5, 'Album 5', DATE("2019-02-22"));

insert into faixa (musica_id, album_id, posicao, descricao) values ('000G1xMMuwxNHmwVsBdtj1', 1, 15, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('000mGrJNc2GAgQdMESdgEc', 1, 11, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('000Npgk5e2SgwGaIsN3ztv', 1, 320, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('000py0jh5yT85aczhQ9QQQ', 1, 144, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('000x2qE0ZI3hodeVrnJK8A', 1, 150, 'Descricao teste, detalhada.');


insert into faixa (musica_id, album_id, posicao, descricao) values ('0012iPKNQl1zhdYwq3iVa1', 2, 285, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('00147h65HDYSncB3byziPP', 2, 194, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('001ZmOPuWEW5czwun7nkha', 2, 7, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('0024tEymsoc9FyKUauQngQ', 2, 495, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('002dh6a4LfxfGGnhPZY4fG', 2, 2201, 'Descricao teste, detalhada.');

insert into faixa (musica_id, album_id, posicao, descricao) values ('003d3VbyJTZiiOYT2W7fnQ', 3, 453, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('003FTlCpBTM4eSqYSWPv4H', 3, 12, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('003JzPprzThp8SHUctgXnn', 3, 44, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('003vvx7Niy0yvhvHt4a68B', 3, 123, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('004ADkC8JLeDkT5HGsPDBm', 3, 45, 'Descricao teste, detalhada.');

insert into faixa (musica_id, album_id, posicao, descricao) values ('004cCP7Csq7U0m67DDzEFs', 4, 74, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('004dqsaJ3B8BBpqpN0F4YT', 4, 47, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('004TG0nRHejwSKisvwTcAB', 4, 41, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('0055LRFB7zfdCXDGodyIz3', 4, 669, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('005GysoS5B8WH372VBNAmT', 4, 8765, 'Descricao teste, detalhada.');

insert into faixa (musica_id, album_id, posicao, descricao) values ('005lwxGU1tms6HGELIcUv9', 5, 4253, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('0068sWyv51jn6VT83EybzR', 5, 543, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('006bxORtP7mtwDtULXaQqG', 5, 4535, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('006fbuXS6rRAWlUEaklCmt', 5, 5457, 'Descricao teste, detalhada.');
insert into faixa (musica_id, album_id, posicao, descricao) values ('00cs7mlkTcIIoWnm8G0U0l', 5, 545, 'Descricao teste, detalhada.');

insert into rotulo (id, descricao) values (1, 'Pop');
insert into rotulo (id, descricao) values (2, 'Rock');
insert into rotulo (id, descricao) values (3, 'New Age');
insert into rotulo (id, descricao) values (4, 'Clássica');
insert into rotulo (id, descricao) values (5, 'Instrumental');
insert into rotulo (id, descricao) values (6, 'Épica');
insert into rotulo (id, descricao) values (7, 'Acústica');

insert into rotulo_musica(musica_id , rotulo_id)
select m.id musica_id, 1 from musica m;
update rotulo_musica set rotulo_id = (select FLOOR(RAND() * 10 - 2));

insert into rotulo_artista(artista_id , rotulo_id)
select a.id artista_id, 1 from artista a;
update rotulo_artista set rotulo_id = (select FLOOR(RAND() * 10 - 2));

insert into musica_relacionada values ('006fbuXS6rRAWlUEaklCmt', '00cs7mlkTcIIoWnm8G0U0l', 'Relacionados teste');
insert into musica_relacionada values ('03uyX5pXSMsZwDaQHrR09o', '01RyLYQRWP02Fstc6DJMgA', 'Relacionados teste');
insert into musica_relacionada values ('03AMfxhiuPDtqVBUGdzFOU', '02YCglF5eNFT2DwEQyq5UV', 'Relacionados teste');
insert into musica_relacionada values ('02DU6l2BdGMpCO3AxuHD59', '03ig8Asct95IIRVbEKvqmm', 'Relacionados teste');
insert into musica_relacionada values ('02smo7WfO95Ww8MZw06h1p', '00nMaqsvj9v1a8Q9B3J44S', 'Relacionados teste');
insert into musica_relacionada values ('01IV32KUgfMLJisLLqBNAF', '01B5omVZrbZdKTEKbnX7VJ', 'Relacionados teste');

/* 9. */
