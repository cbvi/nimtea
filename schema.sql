create table if not exists teas (
	teaid integer primary key,
	name text,
	buy boolean,
	rating integer,
	strength integer,
	comment text);

create index if not exists idx_teaid on teas(teaid);
