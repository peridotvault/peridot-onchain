import { createBrowserRouter } from 'react-router-dom';

import { MainLayout } from './layouts/MainLayout';
import { LandingPage } from './pages/landing/_LandingPage';
import { NotFound } from './pages/additional/NotFound';


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
                path: "*",
                element: <NotFound />
            },
        ]
    },
]);

export default router;
