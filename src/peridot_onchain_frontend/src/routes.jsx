import { createBrowserRouter } from 'react-router-dom';

import { MainLayout } from './components/layout/MainLayout';
import { LandingPage } from './pages/LandingPage';
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
