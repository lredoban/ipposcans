<template>
  <div id="app">
    <div id="img-wrapper" :class="{infos: showInfos}" @click="menuIsOpen = !menuIsOpen">
      <img :src="imgSrc" alt="show me love">
    </div>
    <div class="buttons" :class="{infos: showInfos}">
      <button class="btn" @click="prev">Prev</button>
      <button class="btn" @click="next">Next</button>
    </div>
    <div id="menu" :class="{open: menuIsOpen}">
      <div v-if="!baseUrl">
        <form id="baseUrlForm" @submit.prevent="saveBaseUrl">
          <label for="baseUrl">Add a base url</label>
          <input type="text" name="baseUrl" id="baseUrl">
          <button type="submit">Save</button>
        </form>
      </div>
      <template v-else>
        <button class="btn" @click="currentChapter++">Next Chapter</button>
        <div class="menu-select">
          Choose a chapter:
          <label for="chapter"></label>
          <select v-model="currentChapter" id="chapter">
            <option disabled value>Choisissez</option>
            <option
              v-for="chapter in $_chapters"
              :key="chapter.name"
              :value="chapter.name - 1"
            >{{chapter.name}}</option>
          </select>
        </div>
        <button @click="clearBaseUrl">Clear Base Url</button>
        <div class="menu-credit">
          <small>Made with
            <a href="https://www.buymeacoffee.com/Lova" target="_blank" rel="noopener">🥜</a> by Lova
            <a href="https://lovasoa.fr" target="_blank" rel="noopener">🐯</a>
          </small>
        </div>
      </template>
    </div>
    <div id="progress" ref="progress"></div>
  </div>
</template>

<script>
import { chapters } from "../public/hajime-no-ippo.json";
import { useDeviceMotion } from '@vueuse/core'

export default {
  name: "app",
  data: () => {
    return {
      baseUrl: localStorage.baseUrl || "",
      currentChapter: parseInt(localStorage.currentChapter) || 0,
      currentImg: parseInt(localStorage.currentImg) || 0,
      imgs: [],
      menuIsOpen: false,
      showInfos: false,
      rotationRate: null
    };
  },
  created() {
    this.$_chapters = chapters;
    this.loadChapter(this.$_chapters[this.currentChapter]);
  },
  mounted() {
    this.$_body = document.getElementsByTagName("body")[0];
    this.setProgress();
    this.rotationRate = useDeviceMotion().rotationRate
    if (this.currentImg === 0 && this.currentChapter === 0) {
      this.showInfos = true;
      setTimeout(() => {
        this.showInfos = false;
      }, 5000);
    }
  },
  computed: {
    imgSrc() {
      if (!this.imgs.length || this.currentImg === -1) return "";
      return this.imgs[this.currentImg].src;
    },
    alpha() {
      return this.rotationRate ? Math.round(this.rotationRate.alpha) : 0
    }
  },
  methods: {
    chap() {
      return this.$_chapters[this.currentChapter];
    },
    loadChapter(chapter) {
      this.imgs = chapter.pages.map(page => {
        const img = new Image();
        img.src = `${this.baseUrl}/${chapter.name}/${page}.jpg`;
        return img;
      });
      this.preloadNextImages(+chapter.name)
    },
    preloadNextImages(index) {
      for (let i = index; i < index + 10; i++) {
        if (!this.$_chapters[i]) break;
        this.$_chapters[i].pages.map(page => {
          const src = `${this.baseUrl}/${this.$_chapters[i].name}/${page}.jpg`
          new Image().src = src;
        })
      }
    },
    prev() {
      if (this.currentImg <= 0) {
        this.currentChapter--
        this.$nextTick(() => this.currentImg = this.imgs.length - 1)
      }
      else 
      this.currentImg = this.currentImg - 1;
    },
    next() {
      if (this.currentImg >= this.imgs.length - 1) {
        this.currentChapter++
      } else 
        this.currentImg++;
    },
    setProgress() {
      this.$refs.progress.style.width =
        parseInt(((this.currentImg + 1) / this.imgs.length) * 100) + "vw";
      this.$nextTick(() => this.$_body.scrollBy(9999, 0))
    },
    saveBaseUrl() {
      this.baseUrl = baseUrlForm.baseUrl.value
    },
    clearBaseUrl() {
      this.baseUrl = ''
    }
  },
  watch: {
    alpha(alpha) {
      const minAlpha = 10
      const maxAlpha = 25
      const threshold = 15

      if (Math.abs(alpha) > minAlpha) {
        const max = document.getElementsByTagName('body')[0].clientWidth - document.getElementsByTagName('body')[0].scrollWidth
        const offset = alpha * max / threshold / maxAlpha
        const currentScroll = document.getElementsByTagName('body')[0].scrollLeft
        document.getElementsByTagName('body')[0].scrollLeft = currentScroll + offset
      }
    },
    baseUrl(value) {
      localStorage.baseUrl = value
    },
    currentChapter() {
      this.currentImg = 0;
      this.loadChapter(this.$_chapters[this.currentChapter]);
      localStorage.currentChapter = this.currentChapter;
      this.menuIsOpen = false;
    },
    currentImg() {
      localStorage.currentImg = this.currentImg;
      this.setProgress();
    }
  }
};
</script>

<style>
html,
body {
  padding: 0;
  margin: 0;
  max-height: 100vh;
  overflow-y: hidden;
}
a {
  text-decoration: none;
}
.btn {
  background: whitesmoke;
  border: 1px solid rgb(145, 143, 143);
  padding: 5px 16px;
  border-radius: 3px;
  width: fit-content;
}
#app {
  height: 100vh;
  position: relative;
  font-family: "Avenir", Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
#app .buttons {
  position: fixed;
  bottom: 0;
  height: 36vh;
  display: flex;
  width: 100vw;
}
.buttons button {
  opacity: 0;
  flex: 50%;
  transition: opacity 0.5s ease;
  font-size: 2rem;
  font-weight: 900;
}
.buttons.infos button {
  opacity: 0.4;
}
.buttons button:last-child {
  right: 0;
}
img {
  height: 100%;
}
#img-wrapper {
  height: 100vh;
}
#img-wrapper::before {
  content: "Click in this area to open/close the menu";
  position: fixed;
  top: 0;
  bottom: 36vh;
  background-color: #bada55;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 1.8rem;
  font-weight: 700;
  opacity: 0;
  transition: opacity 0.5s ease;
}
#img-wrapper.infos::before {
  opacity: 0.8;
}
#menu {
  position: fixed;
  top: 100%;
  width: 100vw;
  background-color: #f1e7e7;
  transition: transform 0.4s ease-out;
  padding-top: 1rem;
  display: flex;
  flex-direction: column;
  align-items: center;
}
#menu.open {
  transform: translateY(-100%);
}
#menu > * {
  min-height: 3rem;
}
.menu-credit {
  margin-bottom: 0.3rem;
}
.menu-select {
  margin: 1rem 0;
}
#progress {
  position: fixed;
  top: 0;
  left: 0;
  height: 3px;
  width: 0vw;
  background-color: rgba(240, 128, 128, 0.4);
}
</style>
