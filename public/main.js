window.addEventListener('DOMContentLoaded', function(){
    
    document.querySelector('.filters-btn').addEventListener('click', function(){
        document.body.classList.add('block-scroll')
        document.querySelector('.aside').classList.remove('d-none')
    });

    document.querySelector('.filters-close-btn').addEventListener('click', function(){
        document.body.classList.remove('block-scroll')
        document.querySelector('.aside').classList.add('d-none')
    });

});