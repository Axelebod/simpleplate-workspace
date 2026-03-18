# Tailwind CSS - Référence Wilson

## Installation Rapide
```bash
npx tailwindcss -i ./src/input.css -o ./dist/output.css --watch
```

## Classes Essentielles par Section

### Layout
```
container mx-auto px-4 sm:px-6 lg:px-8
grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6
flex items-center justify-between
min-h-screen
max-w-7xl mx-auto
```

### Typography (Style Apple/Stripe)
```
text-5xl md:text-7xl font-bold tracking-tight
text-xl md:text-2xl text-gray-600 leading-relaxed
text-sm font-medium text-gray-500 uppercase tracking-wider
text-center md:text-left
font-sans (Inter par défaut)
```

### Colors Premium
```
# Couleurs neutres (Apple style)
bg-white, bg-gray-50, bg-gray-900
text-gray-900, text-gray-600, text-gray-400

# Accents (à personnaliser)
bg-blue-600 hover:bg-blue-700
text-blue-600
border-blue-600
```

### Spacing (Design épuré)
```
py-20 md:py-32 (sections grandes)
py-12 (sections moyennes)
space-y-6 (espacement éléments)
gap-8 (grids)
```

### Buttons Premium
```
px-8 py-4 bg-blue-600 text-white font-medium rounded-lg
hover:bg-blue-700 transition-colors duration-200
shadow-lg hover:shadow-xl
```

### Cards
```
bg-white rounded-2xl shadow-sm border border-gray-100
p-8 hover:shadow-lg transition-shadow duration-300
```

### Animations
```
transition-all duration-300 ease-in-out
hover:scale-105 transform
translate-y-0 hover:-translate-y-1
```

### Responsive
```
sm:640px, md:768px, lg:1024px, xl:1280px
hidden md:block (toggle visibility)
flex-col md:flex-row
```

### Hero Section
```html
<section class="relative overflow-hidden bg-gray-900 py-20 sm:py-32">
  <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
    <h1 class="text-5xl md:text-7xl font-bold text-white tracking-tight">
      Titre Impact
    </h1>
    <p class="mt-6 text-xl md:text-2xl text-gray-300 max-w-3xl mx-auto">
      Sous-titre accrocheur
    </p>
    <button class="mt-10 px-8 py-4 bg-blue-600 text-white rounded-lg 
                     hover:bg-blue-700 transition-colors">
      CTA Principal
    </button>
  </div>
</section>
```

### Structure HTML Type
```html
<!-- Container -->
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  
  <!-- Grid services -->
  <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
    
    <!-- Card -->
    <div class="bg-white rounded-2xl p-8 shadow-sm hover:shadow-lg 
                transition-shadow duration-300">
      <div class="w-12 h-12 bg-blue-100 rounded-lg mb-4"></div>
      <h3 class="text-xl font-semibold text-gray-900">Titre</h3>
      <p class="mt-2 text-gray-600">Description</p>
    </div>
    
  </div>
</div>
```

## Tips Premium
- Toujours utiliser `max-w-7xl mx-auto` pour le container
- Espacement généreux avec `py-20 md:py-32` pour les sections
- Contraste élevé (gris foncé sur blanc, blanc sur foncé)
- Border radius modéré (`rounded-lg` ou `rounded-2xl`)
- Ombres subtiles (`shadow-sm` → `shadow-lg` au hover)

---
*Référence rapide pour sites premium 2000€+*