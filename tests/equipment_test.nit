import dummy_db

with ctx = new DBContext do
	var res = ctx.equipment_worker.fetch_multiple(ctx, "* FROM equipments")
	for i in res do print i
end
