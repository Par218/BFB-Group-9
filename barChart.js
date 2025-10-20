/* data */
//note, remove and replace the js with  SQL data tables
const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
const sales_array=[65, 59, 80, 81, 56, 55];
const Production_array=[28, 48, 40, 19, 86, 27];

/* chart creation */
const myChart = new Chart('myChart',{
    type : 'bar',
    data: {
        labels: months,
        datasets: [
            {
            label: 'Sales',
            backgroundColor: 'blue',
            data: sales_array
            },
            {
            label: 'Production',
            backgroundColor: 'orange',
            data: Production_array
            }
        ]
    }

})