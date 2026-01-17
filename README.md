# Portfolio Website

A minimal, self-hosted portfolio website built with vanilla JavaScript, HTML, and CSS.

## Features

- **Home Page**: Main landing page with sections for About, Skills, Projects, and Contact
- **Photos Page**: Minimal, stylish photo gallery with light background design
- **Project Pages**: Individual pages for each project with detailed information
- **Responsive Design**: Fully responsive layout that works on all devices
- **Self-hosted**: No build process required - just static files

## Project Structure

```
portfolio-2/
├── index.html              # Main homepage
├── photos.html             # Photos gallery page
├── projects/               # Individual project pages
│   ├── pr-killer.html
│   └── quick-switcher.html
├── styles/                 # CSS files
│   ├── main.css           # Main styles for homepage
│   ├── photos.css         # Styles for photos page
│   └── project.css        # Styles for project pages
├── scripts/                # JavaScript files
│   ├── main.js           # Main JavaScript functionality
│   └── photos.js         # Photos page functionality
└── assets/                # Images and other assets
    ├── navLogo.png
    ├── me.jpg
    ├── contact.jpg
    ├── projects/
    │   ├── prKiller.png
    │   └── quick-switcher-2.png
    ├── skills/
    │   ├── html.png
    │   ├── css.png
    │   ├── javascript.png
    │   ├── react.png
    │   ├── nextjs.png
    │   ├── node.png
    │   ├── mongo.png
    │   └── tailwind.png
    └── photos/            # Your photos go here
        └── placeholder.jpg
```

## Setup Instructions

1. **Copy Assets**: Copy your assets from the previous portfolio project:
   ```bash
   cp -r /Users/andrey/projects/portfolio/public/assets /Users/andrey/projects/portfolio-2/
   ```

2. **Add Your Photos**: Place your photos in the `assets/photos/` directory. Update `photos.html` to reference your actual photos.

3. **Update Content**: 
   - Edit `index.html` to update your personal information
   - Update the About section with your bio
   - Add/remove projects as needed
   - Update social media links

4. **Install Dependencies** (for local server):
   ```bash
   npm install
   ```

5. **Host Locally**: 
   - Using npm script (recommended):
     ```bash
     npm run serve
     # or
     npm start
     ```
     This will start a server on http://localhost:8000 and open it in your browser.
   
   - Alternative methods:
     ```bash
     # Python 3
     python3 -m http.server 8000
     
     # PHP
     php -S localhost:8000
     
     # Or simply open index.html in a browser
     ```

5. **Deploy**: 
   - **To your server** (45.154.35.21): Run `npm run deploy` or `./deploy.sh`
   - **To other hosting**: Upload all files to your web hosting service. Since it's all static files, you can host it on:
     - GitHub Pages
     - Netlify
     - Vercel
     - Any traditional web hosting
     - Your own server

   See `DEPLOYMENT.md` for detailed deployment instructions.

## Customization

### Colors
The main color scheme uses:
- Primary: `#5651e5` (purple-blue)
- Secondary: `#709dff` (light blue)
- Background: `#ecf0f3` (light gray)
- Text: `#1f2937` (dark gray)

You can change these in `styles/main.css` by searching for the color values.

### Photos Page
The photos page is designed with a minimal, light aesthetic. To add your photos:
1. Place images in `assets/photos/`
2. Update the `photos-grid` div in `photos.html` with your actual images
3. Adjust the grid layout in `styles/photos.css` if needed

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- Mobile browsers (iOS Safari, Chrome Mobile)
- No JavaScript framework dependencies

## Notes

- All images should be optimized for web use
- The contact form currently just shows an alert - you'll need to add backend functionality if you want it to actually send emails
- The photos page uses lazy loading for better performance
- Smooth scrolling is enabled for anchor links

## License

This is a personal portfolio project. Feel free to use it as a template for your own portfolio.
