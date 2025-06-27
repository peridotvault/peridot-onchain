import { createBrowserRouter } from 'react-router-dom';

import { MainLayout } from './layouts/MainLayout';
import { LandingPage } from './pages/LandingPage';
import { NotFound } from './pages/additional/NotFound';
import { DownloadPage } from './pages/DownloadPage';


const router = createBrowserRouter([
    {
        path: "/",
        element: <MainLayout />,
        children: [
            {
                index: true,
                element: <LandingPage />
            },
            {
                path: "download",
                element: <DownloadPage />
            },
            {
                path: "*",
                element: <NotFound />
            },
        ]
    },
]);

export default router;
