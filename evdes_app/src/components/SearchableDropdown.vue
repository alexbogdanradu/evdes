<template>
    <div ref="dropdown" class="relative w-full">
        <!-- Search Input Field -->
        <input type="text" v-model="searchQuery" @focus="isDropdownVisible = true" @input="filterItems"
            :placeholder="searchQuery ? '' : 'Cauta...'"
            class="w-full p-2 text-black placeholder:text-gray-500 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />

        <!-- Dropdown Menu -->
        <div v-if="isDropdownVisible"
            class="absolute z-10 w-full mt-2 bg-white border border-gray-200 rounded-md shadow-lg">
            <ul class="max-h-60 overflow-y-auto">
                <li v-for="item in filteredItems" :key="item.code" @click="selectItem(item)"
                    class="px-4 py-2 text-black hover:bg-gray-100 cursor-pointer">
                    {{ item.code }}: {{ item.description }}
                </li>
            </ul>
        </div>
    </div>

</template>


<script>
import wastesData from '@/assets/wastes.json';

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
            const dropdown = this.$refs.dropdown;
            // Ensure dropdown ref is available before accessing its methods
            if (dropdown && !dropdown.contains(event.target)) {
                this.isDropdownVisible = false;
            }
        },
        selectItem(item) {
            this.selectedItem = item;
            this.$emit('item-selected', item);
            this.isDropdownVisible = false;
        },
        filterItems() {
            this.isDropdownVisible = true;
        },
        normalizeText(text) {
            return text.normalize('NFD').replace(/[\u0300-\u036f]/g, "");
        }
    },
    mounted() {
        this.items = wastesData;
        document.addEventListener('click', this.handleClickOutside);
    },
    beforeDestroy() {
        document.removeEventListener('click', this.handleClickOutside);
    },
    watch: {
        isDropdownVisible(val) {
            if (!val) this.searchQuery = this.selectedItem ? `${this.selectedItem.code} - ${this.selectedItem.description}` : '';
            if (val) this.searchQuery = '';
        }
    }
};
</script>

<style scoped></style>