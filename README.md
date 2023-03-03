# Meak

A synchronised shopping list app.

<div class="container">
  <button class="prev">&#10094;</button>
  <div class="image-container">
    <img src="assets\Screenshots\AddByEmail.jpg" alt="Image 1">
    <img src="assets\Screenshots\AddByQR2.jpg" alt="Image 2">
    <img src="assets\Screenshots\AddItem1.jpg" alt="Image 3">
  </div>
  <div class="image-container">
    <img src="assets\Screenshots\EditProfile.jpg" alt="Image 4">
    <img src="assets\Screenshots\Home1.jpg" alt="Image 5">
    <img src="assets\Screenshots\PersonalSettings.jpg" alt="Image 6">
  </div>
  <div class="image-container">
    <img src="assets\Screenshots\Settings.jpg" alt="Image 7">
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
