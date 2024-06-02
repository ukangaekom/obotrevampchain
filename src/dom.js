// NAVIGATION BUTTONS

const Home = document.querySelector('.home')
const MarketPlace = document.querySelector('.marketplace')
const Project = document.querySelector('.project')
const Setting = document.querySelector('.settings')



// VIEW PAGES
const homePage = document.querySelector('.home_page')
const marketPage = document.querySelector('.market_page')
const projectPage = document.querySelector('.project_page')
const settingsPage = document.querySelector('.settings_page')
const tradingPage = document.querySelector('.tradingPage')



// Pages
const Pages = [homePage, marketPage, projectPage, settingsPage,tradingPage]


// Functionalities to render pages

const render = function (page) {
    
    for (i of Pages) {
        if (page.className == i.className) {
            i.classList.remove('view')
        } else {
            i.classList.add('view')
        }
    }
}




// Dom manipulations

Home.addEventListener('click', function () {
    render(homePage)
})

MarketPlace.addEventListener('click', function () {
    render(marketPage)
})

Project.addEventListener('click', function () {
    render(projectPage)
})

Setting.addEventListener('click', function () {
    render(settingsPage)
})