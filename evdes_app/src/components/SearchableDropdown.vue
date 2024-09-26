<template>
    <div class="searchable-dropdown" ref="dropdown">
        <!-- Search Input Field -->
        <input type="text" v-model="searchQuery" @focus="isDropdownVisible = true" @input="filterItems"
            :placeholder="searchQuery ? '' : 'Search...'" class="search-input" />

        <!-- Dropdown Menu -->
        <div v-if="isDropdownVisible" class="dropdown">
            <ul>
                <li v-for="item in filteredItems" :key="item.code" @click="selectItem(item)" class="dropdown-item">
                    {{ item.code }}: {{ item.description }}
                </li>
            </ul>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return {
            searchQuery: '',
            selectedItem: null,
            isDropdownVisible: false,
            items: []
        };
    },
    computed: {
        filteredItems() {
            const query = this.normalizeText(this.searchQuery.toLowerCase().trim());
            if (!query) return this.items;

            return this.items.filter(item =>
                this.normalizeText(item.description).includes(query) ||
                this.normalizeText(item.code).includes(query)
            );
        }
    },
    methods: {
        handleClickOutside(event) {
            if (!this.$refs.dropdown.contains(event.target)) {
                this.isDropdownVisible = false;
            }
        },
        selectItem(item) {
            this.selectedItem = item;
            this.$emit('item-selected', item);
            this.isDropdownVisible = false;
            this.selectedItem = null;
            this.searchQuery = '';
        },
        filterItems() {
            this.isDropdownVisible = true;
        },
        async fetchItems() {
            try {
                const response = await fetch('./../../src/assets/wastes.json');
                this.items = await response.json();
                console.log(this.items.length);
            } catch (error) {
                console.error('Error fetching the items:', error);
            }
        },
        normalizeText(text) {
            return text.normalize('NFD').replace(/[\u0300-\u036f]/g, "");
        }
    },
    mounted() {
        this.fetchItems();
        document.addEventListener('click', this.handleClickOutside);
    },
    beforeDestroy() {
        document.removeEventListener('click', this.handleClickOutside);
    },
    watch: {
        isDropdownVisible(val) {
            if (!val) this.searchQuery = this.selectedItem ? `${this.selectedItem.code} - ${this.selectedItem.description}` : '';
        }
    }
};
</script>

<style scoped>
.searchable-dropdown {
    position: relative;
    width: 300px;
}

.search-input {
    width: 100%;
    padding: 8px;
    box-sizing: border-box;
}

.dropdown {
    position: absolute;
    width: 100%;
    max-height: 200px;
    overflow-y: auto;
    background: white;
    border: 1px solid #ddd;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    z-index: 1000;
}

.dropdown-item {
    padding: 8px;
    cursor: pointer;
    font-size: xx-small;
}

.dropdown ul {
    list-style-type: none;
    padding: 0;
    margin: 0;
}

.dropdown-item:hover {
    background-color: #f0f0f0;
}
</style>