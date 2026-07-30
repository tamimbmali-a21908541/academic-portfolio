 /*Boshra Alalou 21908516*/
 /*Tamim Mohamed Ali 21908541*/
 /*Sofia Barros Adriano 22104464 */


drop database bd_project;
create DATABASE bd_project;

USE bd_project;



/* **** START OF LOAD TABLES *****/

CREATE TABLE load_song(
        musica_id varchar(24),
        titulo varchar(500),
        ano  varchar(10)
);


CREATE TABLE load_song_detail(
        musica_id varchar(24),
        duracao varchar(30),
        letra_explicita varchar(5),
        popularidade varchar(30),
        grau_dancabilidade varchar(30),
        grau_vivacidade varchar(30),
        volume_som_medio varchar(30)
);


CREATE TABLE load_song_artista(
        musica_id varchar(24),
        artists varchar(600),
        artista_id int
);



/* **** END OF LOAD TABLES *****/


/* **** START OF NON LOAD TABLES *****/


CREATE TABLE musica(
        id varchar(22) primary key,
        titulo varchar(200),
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
        data_lancamento int
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
        nome_artistico varchar(200),
        nome_real varchar(200),
        data_nascimento int,
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

/* **** END OF NON LOAD TABLES ***/


/* **** Second point ( 2. )  *****/

CREATE INDEX load_songs_id
ON load_song (musica_id);
CREATE INDEX load_song_detail_id
ON load_song_detail (musica_id);
CREATE INDEX load_song_artista_id
ON load_song_artista (musica_id);

/* **** Second point ( 2. )  ****/

/* *** Third point ( 3. ) ****/

update load_song set musica_id = TRIM(musica_id), titulo = TRIM(titulo), ano = trim(ano); /*3.1 at load_song*/
update load_song set titulo = substring(titulo,2, char_length(titulo)-2) where titulo like '"%"'; /*3.2 at load_song*/

update load_song_artista set musica_id = TRIM(musica_id), artists = TRIM(artists); /*3.1 at load_song_artista*/
update load_song_artista set artists = substring(artists,2, char_length(artists)-2) where artists like '"%"'; /*3.2 at load_song_artista*/
update load_song_artista set artists = substring(artists,2, char_length(artists)-2) where artists like '[%]'; /*3.3 at load_song_artista*/


update load_song_detail set musica_id = TRIM(musica_id), 
                                duracao = TRIM(duracao), 
                                letra_explicita = TRIM(letra_explicita), 
                                popularidade = TRIM(popularidade), 
                                grau_dancabilidade = TRIM(grau_dancabilidade), 
                                grau_vivacidade = TRIM(grau_vivacidade), 
                                volume_som_medio = TRIM(volume_som_medio); /*3.1 at load_song_artista*/



SELECT *, round((LENGTH(artists) - LENGTH( REPLACE(artists, "'", ""))) / 2) AS count_artists from load_song_artista order by count_artists desc; /*3.4 Counted artists by row: count how many (') are and divide it by 2*/

/* *** Third point ( 3. ) ****/

/* *** Fourth point ( 4. ) ****/

        /*4.1 on load_song*/
        select musica_id, count(*) from load_song group by musica_id having count(*) > 1; /*check if there's repeated musica_id*/
        
        /*4.2 on load_song*/
        alter table load_song add id_temp int; /*add temporary id to load_song*/
        SET @row_number = 0; 
        update load_song set id_temp = @row_number := @row_number + 1; /*set temporary id as rownumber*/
        
        DELETE t1 FROM load_song t1
        INNER JOIN load_song t2 
        WHERE 
            t1.id_temp < t2.id_temp AND 
            t1.musica_id = t2.musica_id; /*Delete using delete join on load_song*/
        /*4.2 on load_song*/
            
        /*4.1 on load_song*/
        select musica_id, count(*) from load_song group by musica_id having count(*) > 1; /*check if there's repeated musica_id*/
        
        /*4.2 on load_song_artista*/
        alter table load_song_artista add id_temp int; /*add temporary id to load_song_artista*/
        SET @row_number = 0; 
        update load_song_artista set id_temp = @row_number := @row_number + 1; /*set temporary id as rownumber*/
        
        DELETE t1 FROM load_song_artista t1
        INNER JOIN load_song_artista t2 
        WHERE 
            t1.id_temp < t2.id_temp AND 
            t1.musica_id = t2.musica_id; /*Delete using delete join on load_song_artista*/
        /*4.2 on load_song_artista*/
            
        
        /*4.2 on load_song_detail*/
        alter table load_song_detail add id_temp int; /*add temporary id to load_song_detail*/
        SET @row_number = 0; 
        update load_song_detail set id_temp = @row_number := @row_number + 1; /*set temporary id as rownumber*/
        
        DELETE t1 FROM load_song_detail t1
        INNER JOIN load_song_detail t2 
        WHERE 
            t1.id_temp < t2.id_temp AND 
            t1.musica_id = t2.musica_id; /*Delete using delete join on load_song_detail*/
        /*4.2 on load_song_detail*/

/* *** Fourth point ( 4. ) ****/