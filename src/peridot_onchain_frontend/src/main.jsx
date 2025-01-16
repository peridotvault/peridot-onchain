import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.scss';
import { RouterProvider } from 'react-router-dom';
import router from './routes';

// Create a root wrapper component
const Root = () => {
  return (
    <RouterProvider router={router} />
  );
};

// Render the app
ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <Root />
  </React.StrictMode>
);