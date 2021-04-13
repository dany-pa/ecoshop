const express = require('express');
const db = require('./db/db.js');
const app = express();

app.set('views', './views')
app.set('view engine', 'pug')

app.use(express.static('public'));

async function getFilters(){
    const filters = {
        type: [],
        material: [],
        shop: []
    }
    
    try{
        const response = await db.query(`SELECT * FROM public.item_types ORDER BY name`)
        filters.type = response.rows;
    } catch(err){
        console.log("getFilters(itemTypes):", err)
    }

    try{
        const response = await db.query(`SELECT * FROM public.materials ORDER BY name`)
        filters.material = response.rows;
    } catch(err){
        console.log("getFilters(material):", err)
    }

    try{
        const response = await db.query(`SELECT * FROM public.shops`)
        filters.shop = response.rows;
    } catch(err){
        console.log("getFilters(shops):", err)
    }

    return filters
}

app.get('/', async (req, res) => {
    const perPage = 10;
    const page = req.query.page || 1;
    const filterType = req.query["filter-type"];
    const filterMaterial = req.query["filter-material"];
    const filters = await getFilters();
    const activeFilters = {
        type: filterType || [],
        material: filterMaterial || []
    };

    const query = {
        text: `
            SELECT 
                * 
            FROM 
                get_products_with_paginaion_and_filters(
                    $1::INTEGER,
                    $2::INTEGER,
                    $3::INTEGER[],
                    $4::INTEGER[]
                )`,
        values: [
            perPage,
            page,
            filterType ? Array(filterType) : filterType,
            filterMaterial ? Array(filterMaterial) : filterMaterial
        ]
    };

    try{
        const response = await db.query(query);
        const data = response.rows;
        res.render('index', {
            title: "Товары", 
            dataList: data,
            curUrl: 'http://' + req.headers.host + req.url,
            paginationLink: req.url,
            curPage: +page,
            pageCount: data[0]?.page_count || 0,
            filters: filters,
            activeFilters: activeFilters
        });
    } catch (err){
        console.log(err)
    }
});

// app.get('/scrap', async (req, res) => {
//     try {
//         await scrap();
//         res.status(200).send({ message: 'УСПЕШНО' })
//     } catch(err){
//         res.status(500).send({ error: err })
//     }
// })

const PORT = process.env.PORT || 3333;
app.listen(PORT, () => {
    console.log(`Application listening on port ${PORT}!`);
});