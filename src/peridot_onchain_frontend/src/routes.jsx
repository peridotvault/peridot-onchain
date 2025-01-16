import { createBrowserRouter } from 'react-router-dom';

import { MainLayout } from './components/layout/MainLayout';
import { LandingPage } from './pages/LandingPage';


const router = createBrowserRouter([
    {
        path: "/",
        element: <MainLayout />,
        children: [
            {
                index: true,
                element: <LandingPage />
            },
        ]
    },
]);

export default router;
