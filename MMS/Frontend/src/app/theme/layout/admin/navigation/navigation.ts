export interface NavigationItem {
  id: string;
  title: string;
  type: 'item' | 'collapse' | 'group';
  translate?: string;
  icon?: string;
  hidden?: boolean;
  url?: string;
  classes?: string;
  exactMatch?: boolean;
  external?: boolean;
  target?: boolean;
  breadcrumbs?: boolean;

  children?: NavigationItem[];
}
export const NavigationItems: NavigationItem[] = [
  {
    id: 'mms',
    title: 'Jay Laxmi Jewellers Dhiran System',
    type: 'group',
    icon: 'icon-navigation',
    children: [
      {
        id: 'mms-dashboard',
        title: 'Dashboard',
        type: 'item',
        url: '/mms/dashboard',
        icon: 'feather icon-home',
        classes: 'nav-item'
      },
      {
        id: 'mms-deposits',
        title: 'All Deposits',
        type: 'item',
        url: '/mms/deposits',
        icon: 'feather icon-list',
        classes: 'nav-item'
      },
      {
        id: 'mms-entry',
        title: 'New Deposit Entry',
        type: 'item',
        url: '/mms/entry',
        icon: 'feather icon-plus-circle',
        classes: 'nav-item'
      },
      {
        id: 'mms-customer-items',
        title: 'Customer Portfolio',
        type: 'item',
        url: '/mms/customer-items',
        icon: 'feather icon-users',
        classes: 'nav-item'
      },
      {
        id: 'mms-merchant',
        title: 'Merchant Transfers',
        type: 'item',
        url: '/mms/merchant',
        icon: 'feather icon-briefcase',
        classes: 'nav-item'
      },
      {
        id: 'mms-reports',
        title: 'Download Reports',
        type: 'item',
        url: '/mms/reports',
        icon: 'feather icon-file-text',
        classes: 'nav-item'
      }
    ]
  },
  {
    id: 'settings-tools',
    title: 'Settings & Testing',
    type: 'group',
    icon: 'icon-settings',
    children: [
      {
        id: 'mms-configs',
        title: 'System Settings',
        type: 'item',
        url: '/mms/configs',
        icon: 'feather icon-settings',
        classes: 'nav-item'
      },
      {
        id: 'mms-enc-test',
        title: 'Encryption Tool',
        type: 'item',
        url: '/mms/enc-test',
        icon: 'feather icon-shield',
        classes: 'nav-item'
      }
    ]
  }
];

