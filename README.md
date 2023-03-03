# Meak

A synchronised shopping list app.

<div class="container">
  <button class="prev">&#10094;</button>
  <div class="image-container">
    <img src="assets\Screenshots\AddByEmail.jpg" alt="Image 1">
    <img src="assets\Screenshots\AddByQR2.jpg" alt="Image 2">
    <img src="assets\Screenshots\Home1.jpg" alt="Image 3">
  </div>
  <button class="next">&#10095;</button>
</div>

<style>
.container {
  position: relative;
}

.prev,
.next {
  position: absolute;
  top: calc(50% - 15px);
  font-size: 30px;
}

.prev {
  left: -15px;
}

.next {
  right: -15px;
}

.image-container {
  display: flex;
  overflow-x: auto;
}

.image-container img {
max-width:100%;
max-height:500px;
}
</style>

<script>
const container = document.querySelector('.container');
const prevBtn = container.querySelector('.prev');
const nextBtn = container.querySelector('.next');
const imageContainer = container.querySelector('.image-container');

prevBtn.addEventListener('click', () => {
imageContainer.scrollLeft -= imageContainer.clientWidth;
});

nextBtn.addEventListener('click', () => {
imageContainer.scrollLeft += imageContainer.clientWidth;
});
</script>
