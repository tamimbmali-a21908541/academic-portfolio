 /*Boshra Alalou 21908516*/
 /*Tamim Mohamed Ali 21908541*/
 /*Sofia Barros Adriano 22104464 */



/*10.*/
CREATE INDEX artista_nome_artistico
ON artista (nome_artistico);

DELETE t1 FROM artista t1
        INNER JOIN artista t2 
        WHERE 
            t1.id < t2.id AND 
            t1.nome_artistico = t2.nome_artistico;
/*10.*/         
/*11.*/

DELETE FROM load_song_artista where musica_id not in (SELECT id from musica);
/*11.*/

/*12.*/
select * from (
select
  musica_id,
  trim(SUBSTRING_INDEX(SUBSTRING_INDEX(artists, ',', numbers.n), ',', -1)) artist, 
  artista_id + numbers.n artista_id,
  n
from
  (select round(artista_id / 100) n from load_song_artista where (select max(LENGTH(artists) - LENGTH( REPLACE ( artists, ",", "")) + 1) from load_song_artista) * 100 >= artista_id) numbers INNER JOIN load_song_artista
  on CHAR_LENGTH(artists)
     -CHAR_LENGTH(REPLACE(artists, ',', ''))>=numbers.n-1
order by
  musica_id, n) t1
  join artista t2 on t1.artist = t2.nome_artistico;
/*12.*/

/*13. using previous query (12.)*/
insert into contribuicao_artista (artista_id, musica_id)
select t2.id, t1.musica_id from (
select
  musica_id,
  trim(SUBSTRING_INDEX(SUBSTRING_INDEX(artists, ',', numbers.n), ',', -1)) artist, 
  artista_id + numbers.n artista_id,
  n
from
  (select round(artista_id / 100) n from load_song_artista where (select max(LENGTH(artists) - LENGTH( REPLACE ( artists, ",", "")) + 1) from load_song_artista) * 100 >= artista_id) numbers INNER JOIN load_song_artista
  on CHAR_LENGTH(artists)
     -CHAR_LENGTH(REPLACE(artists, ',', ''))>=numbers.n-1
order by
  musica_id, n) t1
  join artista t2 on t1.artist = t2.nome_artistico;

/*13.*/

/*14.*/
        /*14.1.*/
                select count(*) Contagem from musica where ano = 2018;
        /*14.1.*/
        /*14.2.*/
                select ano, count(*) Contagem from musica group by ano order by ano;
        /*14.2.*/
        /*14.3.*/
                select titulo, count(*) Contagem from musica group by titulo order by 2 desc;
        /*14.3.*/
        /*14.4.*/
                alter table musica add TIME_MINUTE_SECOND varchar(5);
        /*14.4.*/
        /*14.5.*/
                update rotulo_artista set rotulo_id = (select FLOOR(RAND()*(7-1+1))+1);
                insert into rotulo_artista(artista_id, rotulo_id)
                values (36401, 4), (36401, 5), (36401, 6),
                        (36501, 1), (36501, 2), (36501, 3),
                        (36601, 2), (36601, 2), (36601, 4),
                        (36701, 1), (36701, 2);
                select a.nome_artistico Nome, r.descricao Rotulo from rotulo_artista ra 
                inner join rotulo r on r.id = ra.rotulo_id
                inner join artista a on a.id = ra.artista_id;
        /*14.5.*/
        /*14.6.*/
                select r.id, r.descricao, count(*) Contagem from rotulo r
                join rotulo_artista ra on r.id = ra.rotulo_id
                /*join rotulo_musica rm on r.id = rm.rotulo_id*/
                group by r.id;
        /*14.6.*/
        /*14.7.*/
                SET @ano1 = 2000;
                SET @ano2 = 2010;
                select * from musica where ano <= @ano2 and ano >= @ano1 order by grau_dancabilidade desc limit 10; /*change the number after limit to represent the N variable*/
        /*14.7.*/
        /*14.8.*/
                SET @ano1 = 2000;
                SET @ano2 = 2001;
                select id, nome_artistico from 
                        (select artista_id from contribuicao_artista 
                                where musica_id in (select m.id from musica m where m.ano <= @ano2 and m.ano >= @ano1) 
                                group by artista_id having count(*) = 1) j1
                        join artista a on j1.artista_id = a.id
                        order by nome_artistico;
        /*14.8.*/
        /*14.9.*/
                /* temas ??? */
        /*14.9.*/
        /*14.10.*/
                SET @ano1 = 2000;
                SET @ano2 = 2001;
                select r.descricao, count(*) from 
                        (select artista_id from contribuicao_artista 
                                where musica_id in (select m.id from musica m where m.ano <= @ano2 and m.ano >= @ano1)) a
                        join rotulo_artista ra on ra.artista_id = a.artista_id
                        join rotulo r on r.id = ra.rotulo_id
                        group by  r.descricao
                        order by 2 desc;
        /*14.10.*/
        /*14.11.*/
                select a.nome_artistico, m.ano from contribuicao_artista ca
                join musica m on ca.musica_id = m.id
                join artista a on ca.artista_id = a.id;
        /*14.11.*/
        /*14.12.*/
        /*14.12.*/
/*14.*/